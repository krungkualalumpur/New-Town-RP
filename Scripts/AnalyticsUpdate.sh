#!/bin/bash
midas-clt download Analytics/file.json "2023-09-11 9:00:00.0000" 30 1000000
python Scripts/AnalyticsScript/ProcessData.py
    