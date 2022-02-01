# frozen_string_literal: true

Hanami.application.register_provider :rack_logger do
  start do
    require "hanami/web/rack_logger"

    target.start :logger
    target.start :rack_monitor

    rack_logger = Hanami::Web::RackLogger.new(
      target[:logger],
      filter_params: Hanami.application.configuration.logger.filters
    )

    rack_logger.attach target[:rack_monitor]

    register :rack_logger, rack_logger
  end
end
