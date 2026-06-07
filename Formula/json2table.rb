# frozen_string_literal: true

class Json2table < Formula
  desc "Convert JSON to table output"
  homepage "https://github.com/siakhooi/json2table"
  version "1.1.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Darwin_arm64.tar.gz"
      sha256 "451f3c6398b08e7590b837752d93c20c7b9342a5a5a654adf808f378bf308044"
    end
    on_intel do
      url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Darwin_x86_64.tar.gz"
      sha256 "56ce7dfabc0730a08bd06aa8aff22a36df4087163efe6022ffe43670eb6cee22"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Linux_arm64.tar.gz"
      sha256 "d18c97d1cb8b7b03c1ff20f7441a3622b4abb0504b59d09b604cf3819d2044f2"
    elsif Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Linux_x86_64.tar.gz"
        sha256 "e2afba82a328e53a00a8098f9a3c46a851e0802fa94dee3fd7d1f49a35a4e65f"
      else
        url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Linux_i386.tar.gz"
        sha256 "98c3713d7bbc555574658ee6c0d0b7b5158b16ba606b4065f57e80d839371a9f"
      end
    end
  end

  def install
    bin.install "json2table"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/json2table --version")
  end
end
