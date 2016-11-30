fog_credentials = {
  provider: 'AWS',
  aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
  region: 'us-east-1',
  host: 's3.amazonaws.com',
  endpoint: 'https://s3.amazonaws.com',
}

Fog::Storage.new(fog_credentials).sync_clock

CarrierWave.configure do |config|
  config.fog_credentials = fog_credentials
  config.fog_directory = ENV.fetch("AWS_BUCKET_NAME")
  config.fog_public = true
  config.fog_attributes = { 'Cache-Control'=>'max-age=315576000' }
end
