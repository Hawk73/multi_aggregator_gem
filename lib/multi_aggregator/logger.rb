# frozen_string_literal: true

module MultiAggregator
  class Logger
    def debug(message)
      # TODO: add debug switcher
      log("[DEBUG] #{message}")
    end

    def info(message)
      log("[INFO] #{message}")
    end

    def log_warn(error)
      warn(error.message)
    end

    def warn(message)
      log("[WARN] #{message}")
    end

    def log_error(error)
      error(error.message)
    end

    def error(message)
      log("[ERROR] #{message}")
    end

    def log(message)
      p(message)
    end
  end
end
