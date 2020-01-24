FROM golang:alpine AS terraform-bundler-build

RUN apk add --update --no-cache git make tree bash
ENV GOPATH=/go
RUN mkdir -p $GOPATH/src/github.com/terraform-providers
RUN cd $GOPATH/src/github.com/terraform-providers && git clone https://github.com/terraform-providers/terraform-provider-google.git
RUN cd $GOPATH/src/github.com/terraform-providers/terraform-provider-google && ls -alrt && pwd &&  make build
RUN mkdir -p $GOPATH/src/github.com/hashicorp
RUN cd $GOPATH/src/github.com/hashicorp && git clone https://github.com/hashicorp/terraform.git
RUN cd $GOPATH/src/github.com/hashicorp/terraform && go install ./tools/terraform-bundle
ENV TF_DEV=false
ENV TF_RELEASE=true
COPY my-build.sh $GOPATH/src/github.com/hashicorp/terraform/scripts/
RUN cd $GOPATH/src/github.com/hashicorp/terraform && /bin/bash scripts/my-build.sh
ENV HOME=/root
COPY terraformrc $HOME/.terraformrc
RUN mkdir -p $HOME/.terraform.d/plugin-cache
RUN ls -alrt /go/bin/
RUN cp /go/bin/terraform-provider-google $HOME/.terraform.d/plugin-cache/
#COPY tmp/ $HOME/

ENTRYPOINT ["/bin/sh"]
########################################
FROM alpine:3

RUN ["/bin/sh", "-c", "apk add --update --no-cache bash ca-certificates curl git jq openssh"]

RUN ["bin/sh", "-c", "mkdir -p /src"]

COPY --from=terraform-bundler-build /go/bin/terraform* /bin/

COPY ["src", "/src/"]

# For Testing
#COPY tmp/ /src/

ENTRYPOINT ["/src/main.sh"]
#ENTRYPOINT ["/bin/bash"]