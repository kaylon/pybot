# this is taken from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
# which is just ingenious!
help: ## Displays this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


all_deploy: ## deploys everything on all infrastructure
	export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i ansible/inventory.yml ansible/playbook.yml


status: ## check which machines are up
	ansible all -i ansible/inventory.yml -m ping

reboot: ## reboot all machines
	echo "### rebooting all machines! ###"
	echo "This will look like it is failing because the reboot will terminate the ssh session"
	ansible raspberries -a "/sbin/reboot" -i ansible/inventory.yml --become

temperatures: # check core temp from all machines
	ansible raspberries -a "/opt/vc/bin/vcgencmd measure_temp" -i ansible/inventory.yml



init_venv: ## build local virtualenv
	if [ ! -e "venv/bin/activate_this.py" ] ; then PYTHONPATH=venv ; virtualenv -p python3 --clear venv ; fi

deps: ## install dependencies
	. ./setup_env.sh & PYTHONPATH=venv ; . venv/bin/activate && venv/bin/pip install -U -r requirements.txt && if [ "$(ls requirements)" ] ; then venv/bin/pip install -U -r requirements/* ; fi

freeze: ## write back dependencies
	. venv/bin/activate && venv/bin/pip freeze > requirements.txt

clean_venv: ## purge all things python
	rm -rf venv
