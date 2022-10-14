class Eksctl < Formula
  desc "Simple command-line tool for creating clusters on Amazon EKS"
  homepage "https://eksctl.io"
  url "https://github.com/weaveworks/eksctl.git",
      tag:      "0.115.0",
      revision: "2e9feac31a2c9bc9a78f7193e8c4db5134c886d6"
  license "Apache-2.0"
  head "https://github.com/weaveworks/eksctl.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f0a4e5780d4546675d0d410d5b305499add424ceffd80a7562aac255aebc6adf"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "10e25112b11d786a72889f57c406e941e47ade8e020e4788248b21667565cbb3"
    sha256 cellar: :any_skip_relocation, monterey:       "9b98c3da451082f45e9ec9a83b7a3f99174a451b833f3eb55a671960781855a7"
    sha256 cellar: :any_skip_relocation, big_sur:        "803c37cfdca8c478f032fda0d479942bdb81964d663c63f8fa9206eb02dbc2af"
    sha256 cellar: :any_skip_relocation, catalina:       "80f9e7f461ccab7f14b1b15e27e737a9ab57a512ae17df03682f11be84229879"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "2750f79db5940b72362d2022efc8422929b5f41f265967b3638bf441d926da26"
  end

  depends_on "counterfeiter" => :build
  depends_on "go" => :build
  depends_on "go-bindata" => :build
  depends_on "mockery" => :build
  depends_on "aws-iam-authenticator"

  # Eksctl requires newer version of ifacemaker
  #
  # Replace with `depends_on "ifacemaker" => :build` when ifacemaker > 1.2.0
  # Until then get the resource version from go.mod
  resource "ifacemaker" do
    url "https://github.com/vburenin/ifacemaker/archive/b2018d8549dc4d51ce7e2254d6b0a743643613be.tar.gz"
    sha256 "41888bf97133b4e7e190f2040378661b5bcab290d009e1098efbcb9db0f1d82f"
  end

  def install
    resource("ifacemaker").stage do
      system "go", "build", *std_go_args(ldflags: "-s -w", output: buildpath/"ifacemaker")
    end
    inreplace "build/scripts/generate-aws-interfaces.sh", "${GOBIN}/ifacemaker",
                                                          buildpath/"ifacemaker"

    ENV["GOBIN"] = HOMEBREW_PREFIX/"bin"
    ENV.deparallelize # Makefile prerequisites need to be run in order
    system "make", "build"
    bin.install "eksctl"

    generate_completions_from_executable(bin/"eksctl", "completion")
  end

  test do
    assert_match "The official CLI for Amazon EKS",
      shell_output("#{bin}/eksctl --help")

    assert_match "Error: couldn't create node group filter from command line options: --cluster must be set",
      shell_output("#{bin}/eksctl create nodegroup 2>&1", 1)
  end
end
