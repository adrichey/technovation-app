Geocoder.configure({
  google: {
    api_key: ENV.fetch("GOOGLE_MAPS_API_KEY"),
  },

  bing: {
    api_key: ENV.fetch("BING_MAPS_API_KEY"),
  },

  cache: Rails.cache,
  timeout: 15,
})
