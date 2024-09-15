#!/bin/bash
set -e

time docker build -t bverfg-corona:4.4.0 .

time docker-compose run --rm bverfg-corona Rscript run_project.R
