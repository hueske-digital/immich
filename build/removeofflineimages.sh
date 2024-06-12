#!/bin/bash

if [ -z "$API_TOKEN" ] || [ -z "$LIBRARY_IDS" ] || [ -z "$BASE_URL" ]; then
  echo "Erforderliche Umgebungsvariablen sind nicht gesetzt. Bitte stelle sicher, dass API_TOKEN, LIBRARY_IDS und BASE_URL definiert sind."
  exit 1
fi

IFS=',' read -ra ID_ARRAY <<< "$LIBRARY_IDS"
for id in "${ID_ARRAY[@]}"; do
  echo "Führe API-Aufruf für Library-ID $id aus..."
  RESPONSE=$(curl --location --request POST "$BASE_URL/api/libraries/$id/removeOffline" \
                  --header "x-api-key: $API_TOKEN" \
                  --header "User-Agent: RemoveOfflineCron" \
                  --silent --output /dev/null --write-out "%{http_code} %{json}")

  RESPONSE_CODE=$(echo $RESPONSE | awk '{print $1}')
  JSON_RESPONSE=$(echo $RESPONSE | awk '{print $2}')

  if [ "$RESPONSE_CODE" -ne 204 ]; then
    echo "Ein Fehler ist aufgetreten. Der Server antwortete mit Statuscode $RESPONSE_CODE."
    echo "Fehlermeldung: $JSON_RESPONSE"
    exit 1
  else
    echo "Erfolgreich verarbeitet ($id)."
  fi
done

echo "Alle Anfragen wurden erfolgreich ausgeführt."
