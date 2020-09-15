#!/bin/sh

release_ctl eval --mfa "Altbee.ReleaseTasks.migrate/1" --argv -- "$@"
