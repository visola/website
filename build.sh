#!/bin/bash

CONTENT_DIR=public
PRODUCTION_DIR=../visola.github.io

# Remove old content
rm -Rf $CONTENT_DIR

# Build static content into 'public' folder
hugo

# Clean production dir
rm -Rf $PRODUCTION_DIR/*

cp -R $CONTENT_DIR/* $PRODUCTION_DIR/
