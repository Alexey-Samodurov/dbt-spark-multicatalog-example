#!/bin/sh
${HIVE_HOME}/bin/schematool -dbType postgres -initSchema
${HIVE_HOME}/bin/start-metastore