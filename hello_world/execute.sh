PACKAGE_ADDRESS="0xcfa60f5e3418b326744ef48750272a7b9eb9b5833cfb2b85c890e8a69ca28f1a"

# script to test function of deployed contract 
sui client call --package "$PACKAGE_ADDRESS" --module hello_world --function hello --json

# get the object ID (return a JSON with --json flag)
CREATED_OBJ_ID=$(sui client call \
    --package "$PACKAGE_ADDRESS" \
    --module hello_world \
    --function hello \
    --json \
    | jq -r '.effects.created[0].reference.objectId'
)

# check object
sui client object "$CREATED_OBJ_ID" --json