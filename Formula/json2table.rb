# frozen_string_literal: true

class Json2table < Formula
  desc "Convert JSON to table output"
  homepage "https://github.com/siakhooi/json2table"
  version "1.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Darwin_arm64.tar.gz"
      sha256 "81062dfb421365a79a9cc5d4290d29268c8684b6e9cd202a24b6c32438c0b03b"
    end
    on_intel do
      url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Darwin_x86_64.tar.gz"
      sha256 "a5bb131abb8ee4313ae4202d42702b0cfaa6e3a1c71ef8699d1f31115543eb56"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Linux_arm64.tar.gz"
      sha256 "9dc4faa66348a5e9ac037c6fb4e6fcd6e6bc18a35d56f629dbc031bf0fa226d1"
    elsif Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Linux_x86_64.tar.gz"
        sha256 "faffa4a499b67be44dfa26bbad4011cc6e27b14745c780e7415d55f46232399b"
      else
        url "https://github.com/siakhooi/json2table/releases/download/v#{version}/json2table_#{version}_Linux_i386.tar.gz"
        sha256 "7bf9b10bead781a2f77d134c5cbb07df4cac7109eef329c9faebb18b84493ddf"
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
