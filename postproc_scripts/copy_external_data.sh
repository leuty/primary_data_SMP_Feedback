#!/bin/bash 

rsync -a --ignore-existing $EXTERNAL_DATA/* $WDIR/external_data/data

