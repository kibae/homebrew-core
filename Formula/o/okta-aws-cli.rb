class OktaAwsCli < Formula
  desc "Okta federated identity for AWS CLI"
  homepage "https://github.com/okta/okta-aws-cli"
  url "https://github.com/okta/okta-aws-cli/archive/refs/tags/v2.3.0.tar.gz"
  sha256 "e7ac241007f4a50b637ea2d0d15f3e1123245e3d874c16d7e5d8ab9812688830"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "52294ea0531d62cc989ae3a24627eda2dadaca9185848feaa1535db9b06d6c14"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "7ad292b4ddbd8ed9e7289e4eed6a8cbdff0d87f6aa0d7b43664dff0038622110"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e556a409ad0edaec521319ddd21aa7ff8cfd9f862821d36a19387dbdcb6d897b"
    sha256 cellar: :any_skip_relocation, sonoma:         "5200ed887815b90a6d83f8048e11ed6313b78c8b7d8d6a33b7ebdc80a5d70609"
    sha256 cellar: :any_skip_relocation, ventura:        "1ac849273e709c93d00af4b05658f7c595bcfce4cfea90e6045b75938dc2e382"
    sha256 cellar: :any_skip_relocation, monterey:       "96b806bddbecf61103210c895cdc48cb036e6f8bd33c0c1a57751b562d37996c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "fc44bffc45828b1d7c26fdd50f3d0928de4d5d940e7add1435bed3d393b93d9d"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/okta-aws-cli"
  end

  test do
    output = shell_output("#{bin}/okta-aws-cli list-profiles")
    assert_match "Profiles:", output

    assert_match version.to_s, shell_output("#{bin}/okta-aws-cli --version")
  end
end
