import requests
import json

url = "http://my.meteoblue.com/dataset/query?apikey=7b29a207a0de"

payload = {
    "units": {
        "temperature": "C",
        "velocity": "km/h",
        "length": "metric",
        "energy": "watts"
    },
    "geometry": {
        "type": "Point",
        "coordinates": [9.1829, 48.7758],
        "locationNames": ["Brazil"]
    },
    "format": "json",
    "timeIntervals": [
        "2023-05-01T+00:00/2023-05-07T+00:00"
    ],
    "queries": [{
        "domain": "ERA5T",
        "gapFillDomain": "NEMSGLOBAL",
        "timeResolution": "daily",
        "codes": [
            {"code": 11, "level": "2 m above gnd", "aggregation": "mean"},  
            {"code": 52, "level": "2 m above gnd", "aggregation": "sum"},   
            {"code": 157, "level": "180-0 mb above gnd", "aggregation": "sum"} 
        ]
    }]
}

response = requests.post(
    url,
    headers={"Content-Type": "application/json"},
    data=json.dumps(payload)
)

print(f"Status code: {response.status_code}")
print(f"Response: {response.text}")