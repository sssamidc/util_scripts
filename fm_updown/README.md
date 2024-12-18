## Brief

The below script is written to gracefully bring down FleetManager and bring it
back up. We've added a sleep for 5 seconds in-between to add some buffer between
performing these actions.

## How to use?

You may run the script as -

1. It is. Make sure the script has correct permissions.
2. Through cron. Make sure you redirect the output (and errors) to some log file

## Environment

Tested with the following -

1. docker version: 24.0.7
2. docker-compose version: 1.29.2
3. Fleet Manager version: 4.2.1.3
