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
                 #[
                    # 106.8,
                    # 47.91
                # ]
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
            # {
            #     "domain": "NEMSGLOBAL",
            #     "gapFillDomain": None,
            #     "timeResolution": "daily",
            #     "codes": [
            #         {
            #             "code": 11,
            #             "level": "2 m above gnd",
            #             "aggregation": "max"
            #         }
            #     ],
            # }
        ],
    }

    def set_coordinates(self, latitude, longitude):
        self.body["geometry"]["coordinates"][0] = [longitude, latitude]

    def set_time_interval(self, start, end):
        self.body["timeIntervals"] = [f"{start.strftime("%Y-%m-%d")}T+00:00/{end.strftime("%Y-%m-%d")}T+00:00"]

    def add_query(self, domain, gap_fill_domain,time_resolution, code_dict):
        self.body["queries"].append({
            "domain": domain,
            "gapFillDomain": gap_fill_domain,
            "timeResolution": time_resolution,
            "codes": [
                code_dict
            ]
        })
