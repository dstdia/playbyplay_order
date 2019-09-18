#!/usr/bin/env bash

# Create scratch org
sfdx force:org:create -f config/project-scratch-def.json -a PBP_OOE -s

# Install MyTriggers
# remove comments to install MyTriggers
# sfdx force:package:install -p 04t1i000000gZ4HAAU -w 10

# Push metadata
sfdx force:source:push

# Assign Permissions
sfdx force:user:permset:assign -n logger
sfdx force:user:permset:assign -n Order_of_Execution
sfdx force:user:permset:assign -n Bypass_Permissions

# Load Data
sfdx force:data:bulk:upsert -s Account -f data/Accounts.csv -i ExtId__c -w 10
sfdx force:data:bulk:upsert -s Contact -f data/Contacts.csv -i ExtId__c -w 10
sfdx force:data:bulk:upsert -s Product2 -f data/Products.csv -i ExtId__c -w 10
