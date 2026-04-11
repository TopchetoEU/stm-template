#!/bin/sh

sed -i "/\/\* USER CODE BEGIN PFP \*\//a\
__attribute__((weak)) void setup() {}\
__attribute__((weak)) void loop() {}\
__attribute__((weak)) void _error() {}" "../Core/Src/main.c"
sed -i "/\/\* USER CODE BEGIN 2 \*\//a\
\  setup();" "../Core/Src/main.c"
sed -i "/\/\* USER CODE BEGIN 3 \*\//a\
\    loop();" "../Core/Src/main.c"
sed -i "/\/\* USER CODE BEGIN Error_Handler_Debug \*\//a\
\  _error();" "../Core/Src/main.c"
