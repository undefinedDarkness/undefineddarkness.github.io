#!/usr/bin/env bash

if [ $1 = "reverse" ]; then 
    cp -rv ./.tooling/ ../undefinedDarkness.github.io/
    cp -rv ./generate ../undefinedDarkness.github.io/
    cp -rv ./assets/*.css ../undefinedDarkness.github.io/assets/
else
    cp -rv ../undefinedDarkness.github.io/.tooling ./
    cp -rv ../undefinedDarkness.github.io/generate ./
    cp -rv ../undefinedDarkness.github.io/assets/*.css ./assets/ 
fi