#!/bin/bash
python Scripts/Enums/EnumUpdate.py
python "../Enum-Automation/Scripts/EnumAutomation.py" Scripts/Enums/Enums.json src/Shared/CustomEnum.lua
rojo sourcemap default.project.json --output sourcemap.json