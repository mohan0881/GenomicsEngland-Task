from PIL import Image
import boto3

## Get latest image ##
s3_client = boto3.client('s3')
response = s3_client.list_objects_v2(Bucket='genomicsengland-bucket-a-with-exif', suffix='.jpg')
all = response['Contents']        
latest = max(all, key=lambda x: x['LastModified'])


## Image proceser ##
image = Image.open(latest)

# next 3 lines strip exif
data = list(image.getdata())
image_without_exif = Image.new(image.mode, image.size)
image_without_exif.putdata(data)


## upload lastest image into Bucket B ##

s3.Object('genomicsengland-bucket-b-without-exif','image').copy_from(CopySource='image_without_exif.save("image_file_without_exif.jpg")')