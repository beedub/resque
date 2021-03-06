require "rake"
require "test_helper"
require "mocha"

describe "rake tasks" do
  before do
    Rake.application.rake_require "tasks/resque"
  end

  describe 'resque:work' do

    it "requires QUEUE environment variable" do
      assert_system_exit("set QUEUE env var, e.g. $ QUEUE=critical,high rake resque:work") do
        run_rake_task("resque:work")
      end
    end

    it "works when multiple queues specified" do
      begin
        old_queues = ENV["QUEUES"]
        ENV["QUEUES"] = "high,low"
        Resque::Worker.any_instance.expects(:work)
        run_rake_task("resque:work")
      ensure
        ENV["QUEUES"] = old_queues
      end
    end

  end

  describe 'resque:workers' do

    it 'requires COUNT environment variable' do
      assert_system_exit("set COUNT env var, e.g. $ COUNT=2 rake resque:workers") do
        run_rake_task("resque:workers")
      end
    end

  end

  def run_rake_task(name)
    Rake::Task[name].reenable
    Rake.application.invoke_task(name)
  end

  def assert_system_exit(expected_message)
    begin
      capture_io { yield }
      fail 'Expected task to abort'
    rescue Exception => e
      assert_equal e.message, expected_message
      assert_equal e.class, SystemExit
    end
  end

end
