docker_run:
	docker run -d --name=mosquitto_test_run homesmarthome/mosquitto:latest 
	docker run -d \
	  --name=homeconnect_test_run \
		-v $(PWD)/test/env:/env \
	  $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker ps | grep homeconnect_test_run

docker_stop:
	docker rm -f homeconnect_test_run 2> /dev/null; true
	docker rm -f amazonecho_test_run mosquitto_test_run 2> /dev/null; true