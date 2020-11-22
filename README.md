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


Here are some useful environment variables to add to your ~/.bashrc. These work with the Makefile included to launch jobs and to quickly rebuilt docker images.
I am also including some aliases that i am using that help me quickly get around places and to move files between local and aws s3 easily.
The most import ones are `DOCKERHUB_ACCOUNT`, `DOCKERHUB_USERNAME`, `PRP`

```
  export PATH=/mnt/bin:/mnt/src:$PATH
  export DOCKERHUB_ACCOUNT="docker.io/ioannisa92"
  export DOCKERHUB_USERNAME="ioannisa92"
  export PYTHONPATH=/mnt/src/
  export PYTHONPATH=/mnt/docker_kube/dr_torch/modules/
  export PRP="https://s3.nautilus.optiputer.net"
  export OLDPRP="https://olds3.nautilus.optiputer.net"
  export S3DATA="users/ianastop/data/"
  export S3OUT="users/ianastop/out/"
  export BOP=ianastop@bop.soe.ucsc.edu
  export TAP=ianastop@tap.soe.ucsc.edu
  export CRIMSON=ianastop@crimson.prism
  export SVS=ubuntu@10.50.100.62
  export PRPOUT="s3://stuartlab/users/ianastop/out/"
  export PRPDATA="s3://stuartlab/users/ianastop/DrugResponse/"
  export PRPMODELS="s3://stuartlab/users/ianastop/saved_models/"
  export MUSTARD=ianastop@mustard.prism

  alias l="ls -altr"
  alias codehub="cd /mnt/src/"
  alias view="less -S"
  alias tarball="tar -xzvf"
  alias ndmi="cd /mnt/docker_kube/ndmi/"
  alias dr_torch="cd /mnt/docker_kube/dr_torch/"
```


## 4. Variables to modify in the `job.yml` before launching a job:
  
```
        env:
        - name: {insert your name}
          value: {insert your value}
        - name: {insert your name}
          value: {insert your value}
        - name: {insert your name}
          value: {insert your value}
        - name: {insert your name}
          value: {insert your value}
          
        volumeMounts:
        - mountPath: {path here will be the path when Docker container launches}
          name: {insert your credential name: this is a var for the job.yml only: look at the bottom of the job.yml under volumes}
        - mountPath: {path here will be the path when Docker container launches}
          name: {insert your credential name: this is a var for the job.yml only: look at the bottom of the job.yml under volumes}
          readOnly: true
        - mountPath: {path here will be the path when Docker container launches}
          name: {insert your credential name: this is a var for the job.yml only: look at the bottom of the job.yml under volumes}
        
        volumes:
        - name: {name from volumeMounts)
          emptyDir: {} # keep as is if the name is for storage of data or scripts
        - name: {name from volumeMounts)
          emptyDir: {}   # keep as is if the name is for storage of data or scripts
        - name: {aws name from volumeMounts)
          secret:
            secretName: {your secres name} # as you made them in step #3
```

## 5. I have included a "hello world" app to run on PRP. The following are the general steps i take before launcing a job on the PRP:

  1. Create, build, and push your docker image with: 
     
     `make docker-make img={your_img_name} version={your_version_number}`
     
     This will use the `Dockerfile` in this repo to build and push the image
     
  2. Modify `job.yml` with your job name and your docker image name:
      ```
      metadata:
        # Prefix name of job with user and timestamp
        #name: $USER
        name: {your_job_name}
        namespace: stuartlab # leave as is
        
      - name: magic
        image: $DOCKERHUB_ACCOUNT/{you_docer_img}:{your_docker_image_version}
        imagePullPolicy: Always
      ```
        
  3. Run job:
  
     `make run-job`
     
  4. Check if pod has launched:
  
     `make get-pods`
     
     This will list of the pods running. Output will look like this
     
     ```
     # Get all pods
      kubectl get pods
      NAME                 READY   STATUS        RESTARTS   AGE
      example-p9pwb   1/1     Terminating   0          2d5h
     ```
     
  5. Check progress of pod:
  
     `make kube-log pod=example-p9pwb`
     
     Will output whatever your script prints in stdout. For our example script it will be endless hello!
     
  6. Delete job
  
     `make delete-job job=examples`
     
     OR delete pod only with the following
     
     `make delete-pod pod=example-p9pwb`
     




