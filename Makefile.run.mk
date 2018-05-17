docker_run:
	docker run -d --name=mosquitto_test_run -p 1883:1883 homesmarthome/mosquitto:latest 
	sleep 20
	docker run -d \
	  --name=php-mosquitto_test_run \
	  --link mosquitto_test_run:mosquitto \
	  -v $(PWD)/test/env:/env \
	  $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker ps | grep php-mosquitto_test_run
	sleep 300

docker_stop:
	docker rm -f php-mosquitto_test_run 2> /dev/null; true
	docker rm -f mosquitto_test_run 2> /dev/null; true