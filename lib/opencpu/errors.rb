module OpenCPU
  module Errors
    class OpenCPUError < StandardError; end
    class BadRequest < OpenCPUError; end
    class InternalServerError < OpenCPUError; end
    class AccessDenied < OpenCPUError; end
    class UnknownError < OpenCPUError; end
  end
end
