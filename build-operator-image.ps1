Param(
    [parameter(Mandatory = $false)][bool]$PublishToDockerHub = $false
)


function Exec {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = 1)][scriptblock]$cmd,
        [Parameter(Position = 1, Mandatory = 0)][string]$errorMessage = ($msgs.error_bad_command -f $cmd)
    )
    & $cmd
    if ($lastexitcode -ne 0) {
        throw ("Exec: " + $errorMessage)
    }
}

#Select the UI version from dependencies.props and use it as image version


$version = select-xml -Path .\build\dependencies.props -XPath "/Project/PropertyGroup[contains(@Label,'Health Checks Package Versions')]/HealthChecksUIK8sOperator"

$tag = $version.node.InnerXML

#Building docker image

echo "Building k8s operator docker image with tag: $tag"
#Publish it

if ($PublishToDockerHub) {

  echo ".. and publishing to Docker Hub"
  exec { & docker buildx build . --platform=linux/arm64  --platform=linux/amd64 --push -f .\src\HealthChecks.UI.K8s.Operator\Dockerfile -t xabarilcoding/healthchecksui-k8s-operator:$tag -t xabarilcoding/healthchecksui-k8s-operator:latest }
  echo "Published to Docker Hub"
}
else {
  exec { & docker buildx build . --load -f .\src\HealthChecks.UI.K8s.Operator\Dockerfile -t xabarilcoding/healthchecksui-k8s-operator:$tag -t xabarilcoding/healthchecksui-k8s-operator:latest }
  echo "Created docker image healthchecksui-k8s-operator:$tag. You can execute this image using docker run"
}
