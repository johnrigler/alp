tf.public_ip () 
{ 
    : region aws us-east-1;
    : region aws us-west-1;
    a.f tf.public_ip | grep '   : region aws' | grep -v grep | cut -c 18- | while read REGION; do
        REGION=$(echo $REGION | sed 's/;//');
        grep '"public_ip":' $_TF_DIR/$REGION/terraform.tfstate | cut -c 27- | sed 's/",//g';
    done
}
