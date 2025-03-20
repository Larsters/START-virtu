import json


class MeteoblueQuery:
    body = {
        "units": {
            "temperature": "C",
            "velocity": "km/h",
            "length": "metric",
            "energy": "watts",
        },
        "geometry": {
            "type": "MultiPoint",
            "coordinates": [
                [
                    # 106.8,
                    # 47.91
                ]
            ],
            "locationNames": [""],
            "mode": "preferLandWithMatchingElevation",
        },
        "format": "json",
        "timeIntervals": [
            # "2024-01-01T+00:00/2024-01-02T+00:00"
        ],
        "timeIntervalsAlignment": "none",
        "queries": [
            {
                "domain": "NEMSGLOBAL",
                "gapFillDomain": None,
                "timeResolution": "daily",
                "codes": [
                    {
                        # "code": 11,
                        # "level": "2 m above gnd",
                        # "aggregation": "max"
                    }
                ],
            }
        ],
    }

    def set_coordinates(self, latitude, longitude):
        self.body["geometry"]["coordinates"][0] = [longitude, latitude]

    def set_time_interval(self, start, end):
        self.body["timeIntervals"] = [f"{start.strftime("%Y-%m-%d")}T+00:00/{end.strftime("%Y-%m-%d")}T+00:00"]

    def set_code(self, domain, time_resolution, code, level, aggregation):
        self.body["queries"][0]["domain"] = domain
        self.body["queries"][0]["timeResolution"] = time_resolution
        self.body["queries"][0]["codes"][0]["code"] = code
        self.body["queries"][0]["codes"][0]["level"] = level
        self.body["queries"][0]["codes"][0]["aggregation"] = aggregation

    def to_json(self):
        return json.dumps(self.body)

    def get_body(self):
        return self.body
