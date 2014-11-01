#!/usr/bin/env ruby

require_relative '../bash_colors'

# Read this blog to know more about this script.
#
# http://blog.bigbinary.com/2013/09/19/do-not-allow-force-pusht-to-master.html

class PrePushHandler

  def handle
    reject if pushing_to_master? && forced_push?
  end

  private

  def pushing_to_master?
    current_branch == 'master'
  end

  def current_branch
    result = %x{git branch}.split("\n")
    if result.empty?
      feedback "It seems your app is not a git repository."
    else
      result.select { |b| b =~ /^\*/ }.first.split(" ").last.strip
    end
  end

  def reject
    messages = ["Your attempt to #{Bash::Text.red{ "FORCE PUSH to MASTER" }} has been rejected."]
    messages << "If you still want to FORCE PUSH then you need to ignore the pre_push git hook by executing following command."
    messages << "git push master --force --no-verify"
    feedback messages
  end

  def forced_push?
    ppid = Process.ppid
    cmd = "ps -ocommand= -p #{ppid}"
    output = `#{cmd}`
    output.match(/--force|-f/)
  end

  def feedback messages
    puts "*"*40
    [messages].flatten.each do |message|
      puts message
    end
    puts "*"*40

    exit 1
  end
end

PrePushHandler.new.handle
