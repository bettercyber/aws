## Docker Events Monitoring with Wazuh
The following Docker events are logged in the Docker host when stopping and starting a Docker container:
|STOP Events|START Events|
|--|--|
|container kill|container create|
|container die|network connect|
|network disconnect|container start|
|container stop|container rename|
|container destroy|container attach|

### Wazuh Docker Listener
Wazuh's Docker Listener listens for Docker events in the Docker host running the containers and will send an email alert when a Docker container is stopped. It will also send an email alert when a Docker container is started. Email alerts will be triggered based on the following events: 
* container stop
* network disconnect
* container die
* container kill
* container destroy
* container start

local_rules.xml
```
<group name="docker,">
<rule id="87924"  level="10" overwrite="yes">
    <if_sid>87900</if_sid>
    <field name="docker.status">^kill$|^die$</field>
    <description>Docker: Container $(docker.Actor.Attributes.name) received the action: $(docker.status)</description>
    <group>gdpr_IV_32.2,</group>
    <options>no_full_log</options>
</rule>
<rule id="87929" level="10" overwrite="yes">
    <if_sid>87927</if_sid>
    <field name="docker.Action">^disconnect$</field>
    <description>Docker: Network $(docker.Actor.Attributes.name) disconnected</description>
    <options>no_full_log</options>
</rule>
<rule id="87903" level="10" overwrite="yes">
    <if_sid>87900</if_sid>
    <field name="docker.status">^start$</field>
    <description>Docker: Container $(docker.Actor.Attributes.name) started</description>
    <options>no_full_log</options>
</rule>
<rule id="87904" level="10" overwrite="yes">
    <if_sid>87900</if_sid>
    <field name="docker.status">^stop$</field>
    <description>Docker: Container $(docker.Actor.Attributes.name) stopped</description>
    <options>no_full_log</options>
</rule>

<rule id="87902" level="10" overwrite="yes">
    <if_sid>87900</if_sid>
    <field name="docker.status">^destroy$</field>
    <description>Docker: Container $(docker.Actor.Attributes.name) destroyed</description>
    <mitre>
        <id>T1488</id>
    </mitre>
    <group>pci_dss_10.2.7,pci_dss_11.5,hipaa_164.312.b,hipaa_164.312.c.1,hipaa_164.312.c.2,nist_800_53_AU.14,nist_800_53_SI.7,tsc_CC6.8,tsc_CC7.2,tsc_CC7.3,tsc_PI1.4,tsc_PI1.5,tsc_CC6.1,</group>
    <options>no_full_log</options>
</rule>
</group>
```
