# signature prepare
ActiveStorage::Blob.create_and_upload!(io: Rails.root.join("Gemfile").open, filename: 'Gemfile')
Rails.application.routes.default_url_options[:host] = '0.0.0.0'
Rails.application.routes.default_url_options[:port] = '3000'
Rails.application.routes.url_helpers.url_for(ActiveStorage::Blob.last!)
