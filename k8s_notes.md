---
# Thu Oct 24 11:15:14 PDT 2019 chrisw

These are steps that I took to get setup to use the PRP computing cluster (Nautilus).

The steps are:

1. Setup AWS S3 credentials to access the Stuart Lab S3 storage.
2. Setup k8s credentials to access the computing cluster.
3. Create k8s secret to allow k8s nodes to access the persistent S3 storage.

## 1. Create AWS credentials

- This step sets up the AWS credentials for accessing the Nautilus/PRP AWS S3 storage that is designated for Stuartlab.

- The AWS credentials will go in `~/.aws/`

- install python aws tool with `pip install awscli`

- Do `aws configure` to set up AWS access to stuartlab bucket.

	~~We're using the old, recovered stuartlab s3 bucket for now. New one will be created by Yianni some time soon. For now, use these settings when prompted by the `aws` tool as shown for `prp`:~~

	It seems we're now switched over to the new one, `stuartlab`:

	```
	[prp]
	access_key=GW3QZHTG9J5903DRI7Q8
	secret_key=9XuPAOO3va0Klmb0lIXVXvTzyMgAfdsHqkCTNdN2

	[stuartlab]
	access_key=19VE6E4LQOWC45IYUUN1
	secret_key=yge2f5Bz26rJNMRgPb6tfi7Jt23PVhED8miwpx9f
	```

	The region is `us-west-2` and output is `json`.

- You can check your configs with `aws configure list`.  Output looks something like:

	```
	> aws configure list
	Name                    Value             Type    Location
	----                    -----             ----    --------
	profile                <not set>             None    None
	access_key     ****************I7Q8 shared-credentials-file
	secret_key     ****************NdN2 shared-credentials-file
	region                us-west-2      config-file    ~/.aws/config
	```

- Test the config with `aws --endpoint https://s3.nautilus.optiputer.net s3 ls s3://stuartlab`. The output looks like:

	```
			PRE foo/
			PRE pancan-gtex/
			PRE users/
	2018-11-23 17:26:45 1003836744 pancan-gtex
	```

	NOTE: The previous endpoint was `https://olds3.nautilus.optiputer.net`. Don't use that one.

## 2. Create k8s credentials

- This step installs the `kubectl` tool and then configures k8s to work with the Nautilus cluster.

- `kubectl` will put k8s credentials will go in `~/.kube`.

- k8s has pretty good documentation for installing `kubectl`. Here, we follow the steps at [https://kubernetes.io/docs/tasks/tools/install-kubectl/](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

- Yianni is using v1.15.4, so I'm going to use the same. There is a curl within a curl that needs to be edited to get the correcte version. Here's what I use:

	```
	curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.4/bin/linux/amd64/kubectl
	```

- Now set up your PRP credentials... go to [https://nautilus.optiputer.net/](https://nautilus.optiputer.net/).

  - You'll be asked for your UCSC gold credentials.

  - Top-right of the home screen has a button, `get config`. Click it.

  - put the config file in a `~/.kube` directory.

- To test the connection to PRP, do `kubectl get pods`. The expected output is `No resources found.` because you haven't spun up any nodes, yet.


## 3. creating secrets with kubectl

- This step is to make it so your k8s pods can reach your aws s3 bucket.

- Here's a webpage about `secrets`: `https://kubernetes.io/docs/concepts/configuration/secret/`.

- Do this example in your `~/.aws/` directory:

	```
	kubectl create secret generic s3-credentials --from-file=credentials
	```

    Here, `s3-credentials` is the name given to the secret... make your own descriptive name for your secret.

- Check your secrets with:

	```
	kubectl get secrets
	```

- Secret can be deleted with:

	```
	kubectl delete secret name-of-some-secret
	```


Yianni also set up some environment variables in his master that make it easier for him to write his kubernetes yaml files.

```
	export DOCKERHUB_ACCOUNT="docker.io/ioannisa92"
	export DOCKERHUB_USERNAME="ioannisa92"
	export PYTHONPATH=/mnt/src/
	export PRP="https://s3.nautilus.optiputer.net"
	export OLDPRP="https://olds3.nautilus.optiputer.net"
	export S3DATA="users/ianastop/data/"
	export S3OUT="users/ianastop/out/"
```

## 4. test out allocation of kube nodes with yianni's hello world web server.

(TO BE CONTINUED)





