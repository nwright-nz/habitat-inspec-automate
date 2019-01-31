Habitat Inspec Automate example
=====================

This is an example of how to use habitat to run an inspec profile and report compliance to Automate. 
Standard 'built on the shoulders of giants' disclaimer: I have not modified the DevSec Linux Baseline control here (<https://github.com/dev-sec/linux-baseline>), and the habitat piece was guided by the AWESOME tutorial here : <https://youtu.be/xJRnmfwjezA> . I've just modified the run hook to report back to Automate, and fixed the plan so the hab pkg build command will work outside studio.


### Configuration
In order to report status to Automate, we need to use the automate reporter. This takes a JSON file as an argument, and the skeleton of this file is in the `habitat/config/reporter.json` file : 
``` json
{ 
    "reporter": {
    "automate" : {
        "stdout" : true,
        "url" : "https://{{cfg.a2url}}/data-collector/v0/",
        "token" : "<TOKEN>",
        "insecure" : true,
        "node_name" : "<NAME>",
        "node_uuid" : "<UUID>",  
        "environment" : "{{cfg.environment}}"
    }
}
}
```

To specify your A2 server and environment, update the default.toml file.   

`<NAME>` is populated by the $HOSTNAME environment variable   
`<UUID>` is populated by the following command: `cat /sys/class/dmi/id/product_uuid`   
`<TOKEN>` is populated with the A2TOKEN environment variable

### Run Hook changes
The habitat setup was done with the inspec habitat integration. The following command was run in the root of the Inspec profile :
```text 
inspec habitat profile setup .
```
This will create the plan, and the run hook. 

The following lines were added to the run hook to populate the json config file: 
```text
UUID=`cat /sys/class/dmi/id/product_uuid`

sed -i "s/<TOKEN>/$A2TOKEN/g; s/<NAME>/$HOSTNAME/g; s/<UUID>/$UUID/g" {{pkg.svc_config_path}}/reporter.json
```
And the `inspec exec` line was modified to the below to use the Automate reporter:
```text
inspec exec "{{pkg.path}}/profiles/*" --json-config={{pkg.svc_config_path}}/reporter.json > ${RESULTS_FILE}
```

