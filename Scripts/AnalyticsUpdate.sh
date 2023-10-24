#!/bin/bash
midas-clt download Analytics/file.json "2023-10-21 12:00:00.0000" 30 1000000
python Scripts/AnalyticsScript/ProcessData.py
    