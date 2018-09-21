# This script startups up nginx in daemon mode after a set amount of time,
# then it termiantes after a set amount of time. It also catches SIGTERM and deletes
# a web page which is the health check, then sleeps for 45 seconds.
# The goal is to simulate a slow starting app that is enabled for graceful shutdown.
# By JoshB @ Mesosphere, Revision 9-20-18

# A signal handler to shutdown cleanly.
# App definition has a shutdown delay (taskKillGracePeriodSeconds) of 60 seconds, 
# thus after sigterm is sent marathon will give the app 60 seconds to shutdown before sigkill is sent.
# During that time NGINX will no long provide it's /healthy endpoint
shutdown() {
  echo
  echo $(date)
  echo "Either the SIGTERM signal was recieved from marathon, or the this startup script" 
  echo "called this shutdown function because $RUN_TIME_SECONDS seconds has elapsed."
  echo
  echo "Shutting down gracefully."
  echo "Removing /healthy.html endpoint /usr/share/nginx/html/healthy.html"
  rm -f /usr/share/nginx/html/healthy.html
  echo
  echo "Sleeping for 45 seconds so health check can fail and the load balancer can"
  echo "withdrawl the app."
  sleep 45
  echo
  echo Exiting
  echo
  exit 0
}

# Catch SIGTERM and run shutdown()
trap shutdown TERM

# EXTRA_STARTUP_DELAY is added to STARTUP_DELAY_SECONDS so that when
# a bunch of container instances startup at the same time they don't all
# start nginx at the same time, in order to better simulate the real world.
# The value will be between 0-9 seconds.
# Using urandom since bash's $random will result in the same value
# in every container instance.
EXTRA_STARTUP_DELAY=$(cat /dev/urandom | tr -dc '0-9' | fold -w 1 | head -n 1)

# STARTUP_DELAY_SECONDS is how long of a delay before starting NGINX. 
# Health and readiness checks will fail during this time
echo
if [ -z "$STARTUP_DELAY_SECONDS" ] 
then
   echo No STARTUP_DELAY_SECONDS varible set, defaulting to 30 seconds
   STARTUP_DELAY_SECONDS=30
fi

echo STARTUP_DELAY_SECONDS is $STARTUP_DELAY_SECONDS seconds
echo EXTRA_STARTUP_DELAY is $EXTRA_STARTUP_DELAY seconds
STARTUP_DELAY_SECONDS=$(($STARTUP_DELAY_SECONDS + $EXTRA_STARTUP_DELAY))
echo NGINX will be started in $STARTUP_DELAY_SECONDS seconds

# RUN_TIME_SECONDS plus EXTRA_RUN_TIME is how long NGINX will be ran
echo
if [ -z "$RUN_TIME_SECONDS" ] 
then
   echo No RUN_TIME_SECONDS varible set, defaulting to 180
   RUN_TIME_SECONDS=180
fi

EXTRA_RUN_TIME=$(cat /dev/urandom | tr -dc '0-9' | fold -w 2 | head -n 1)
echo RUN_TIME_SECONDS is $RUN_TIME_SECONDS
echo EXTRA_RUN_TIME is $EXTRA_RUN_TIME
RUN_TIME_SECONDS=$((RUN_TIME_SECONDS + $EXTRA_RUN_TIME))
echo "NGINX will be ran for $RUN_TIME_SECONDS seconds"

echo
echo "Now sleeping for $STARTUP_DELAY_SECONDS seconds before starting NGINX."
echo "This simulates a slow starting app."
sleep $STARTUP_DELAY_SECONDS
echo
echo Done sleeping, now starting NGINX
echo
# Starting NGINX in its default daemon mode, thus execution will return to this script
nginx
echo
echo "NGINX started, shutting down in $RUN_TIME_SECONDS seconds." 
echo
sleep $RUN_TIME_SECONDS
shutdown

