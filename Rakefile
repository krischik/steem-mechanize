require 'bundler/gem_tasks'
require 'steem-mechanize'

task default: 'test:threads'

desc 'Ruby console with steem-mechanize already required.'
task :console do
  exec 'irb -r steem-mechanize -I ./lib'
end

namespace :test do
  desc 'Tests the mechanized API using multiple threads.'
  task :threads do
    next if !!ENV['TEST']
    
    threads = []
    api = Steem::Api.new(url: ENV['TEST_NODE'])
    database_api = Steem::DatabaseApi.new(url: ENV['TEST_NODE'])
    witnesses = {}
    keys = %i(created url total_missed props running_version
      hardfork_version_vote hardfork_time_vote)
    
    if defined? Thread.report_on_exception
      Thread.report_on_exception = true
    end
    
    database_api.get_active_witnesses do |result|
      print "Found #{result.witnesses.size} witnesses ..."
      
      result.witnesses.each do |witness_name|
        threads << Thread.new do
          api.get_witness_by_account(witness_name) do |witness|
            witnesses[witness.owner] = witness.map do |k, v|
              [k, v] if keys.include? k.to_sym
            end.compact.to_h
            
            sbd_exchange_rate = witness[:sbd_exchange_rate]
            base = sbd_exchange_rate[:base].to_f
            
            if (quote = sbd_exchange_rate[:quote].to_f) > 0
              rate = (base / quote).round(3)
              witnesses[witness.owner][:sbd_exchange_rate] = rate
            else
              witnesses[witness.owner][:sbd_exchange_rate] = nil
            end
            
            last_sbd_exchange_update = witness[:last_sbd_exchange_update]
            last_sbd_exchange_update = Time.parse(last_sbd_exchange_update + 'Z')
            last_sbd_exchange_elapsed = '%.2f hours ago' % ((Time.now.utc - last_sbd_exchange_update) / 60)
            witnesses[witness.owner][:last_sbd_exchange_elapsed] = last_sbd_exchange_elapsed
          end
        end
      end
    end
    
    threads.each do |thread|
      print '.'
      thread.join
    end
    
    puts ' done!'
    
    if threads.size != witnesses.size
      puts "Bug: expected #{threads.size} witnesses, only found #{witnesses.size}."
    else
      puts JSON.pretty_generate witnesses rescue puts witnesses
    end
  end
end  

namespace :stream do
  desc 'Test the ability to stream a block range.'
  task :block_range, [:mode, :at_block_num] do |t, args|
    mode = (args[:mode] || 'irreversible').to_sym
    first_block_num = args[:at_block_num].to_i if !!args[:at_block_num]
    stream = Steem::Stream.new(url: ENV['TEST_NODE'], mode: mode)
    api = Steem::Api.new(url: ENV['TEST_NODE'])
    last_block_num = nil
    last_timestamp = nil
    range_complete = false
    
    api.get_dynamic_global_properties do |properties|
      current_block_num = if mode == :head
        properties.head_block_number
      else
        properties.last_irreversible_block_num
      end
      
      # First pass replays latest a random number of blocks to test chunking.
      first_block_num ||= current_block_num - (rand * 200).to_i
      
      range = first_block_num..current_block_num
      puts "Initial block range: #{range.size}"
      
      stream.blocks(at_block_num: range.first) do |block, block_num|
        current_timestamp = Time.parse(block.timestamp + 'Z')
        
        if !range_complete && block_num > range.last
          puts 'Done with initial range.'
          range_complete = true
        end
        
        if !!last_timestamp && block_num != last_block_num + 1
          puts "Bug: Last block number was #{last_block_num} then jumped to: #{block_num}"
          exit
        end
        
        if !!last_timestamp && current_timestamp < last_timestamp
          puts "Bug: Went back in time.  Last timestamp was #{last_timestamp}, then jumped back to #{current_timestamp}"
          exit
        end
        
        puts "\t#{block_num} Timestamp: #{current_timestamp}, witness: #{block.witness}"
        last_block_num = block_num
        last_timestamp = current_timestamp
      end
    end
  end
  
  desc 'Test the ability to stream a block range of transactions.'
  task :trx_range, [:mode, :at_block_num] do |t, args|
    mode = (args[:mode] || 'irreversible').to_sym
    first_block_num = args[:at_block_num].to_i if !!args[:at_block_num]
    stream = Steem::Stream.new(url: ENV['TEST_NODE'], mode: mode)
    api = Steem::Api.new(url: ENV['TEST_NODE'])
    
    api.get_dynamic_global_properties do |properties|
      current_block_num = if mode == :head
        properties.head_block_number
      else
        properties.last_irreversible_block_num
      end
      
      # First pass replays latest a random number of blocks to test chunking.
      first_block_num ||= current_block_num - (rand * 200).to_i
      
      stream.transactions(at_block_num: first_block_num) do |trx, trx_id, block_num|
        puts "#{block_num} :: #{trx_id}; ops: #{trx.operations.map(&:type).join(', ')}"
      end
    end
  end
  
  desc 'Test the ability to stream a block range of operations.'
  task :op_range, [:mode, :at_block_num] do |t, args|
    mode = (args[:mode] || 'irreversible').to_sym
    first_block_num = args[:at_block_num].to_i if !!args[:at_block_num]
    stream = Steem::Stream.new(url: ENV['TEST_NODE'], mode: mode)
    api = Steem::Api.new(url: ENV['TEST_NODE'])
    
    api.get_dynamic_global_properties do |properties|
      current_block_num = if mode == :head
        properties.head_block_number
      else
        properties.last_irreversible_block_num
      end
      
      # First pass replays latest a random number of blocks to test chunking.
      first_block_num ||= current_block_num - (rand * 200).to_i
      
      stream.operations(at_block_num: first_block_num) do |op, trx_id, block_num|
        puts "#{block_num} :: #{trx_id}; op: #{op.type}"
      end
    end
  end
  
  desc 'Test the ability to stream a block range of virtual operations.'
  task :vop_range, [:mode, :at_block_num] do |t, args|
    mode = (args[:mode] || 'irreversible').to_sym
    first_block_num = args[:at_block_num].to_i if !!args[:at_block_num]
    stream = Steem::Stream.new(url: ENV['TEST_NODE'], mode: mode)
    api = Steem::Api.new(url: ENV['TEST_NODE'])
    
    api.get_dynamic_global_properties do |properties|
      current_block_num = if mode == :head
        properties.head_block_number
      else
        properties.last_irreversible_block_num
      end
      
      # First pass replays latest a random number of blocks to test chunking.
      first_block_num ||= current_block_num - (rand * 200).to_i
      
      stream.operations(at_block_num: first_block_num, only_virtual: true) do |op, trx_id, block_num|
        puts "#{block_num} :: #{trx_id}; op: #{op.type}"
      end
    end
  end
  
  desc 'Test the ability to stream a block range of all operations (including virtual).'
  task :all_op_range, [:mode, :at_block_num] do |t, args|
    mode = (args[:mode] || 'irreversible').to_sym
    first_block_num = args[:at_block_num].to_i if !!args[:at_block_num]
    stream = Steem::Stream.new(url: ENV['TEST_NODE'], mode: mode)
    api = Steem::Api.new(url: ENV['TEST_NODE'])
    
    api.get_dynamic_global_properties do |properties|
      current_block_num = if mode == :head
        properties.head_block_number
      else
        properties.last_irreversible_block_num
      end
      
      # First pass replays latest a random number of blocks to test chunking.
      first_block_num ||= current_block_num - (rand * 200).to_i
      
      stream.operations(at_block_num: first_block_num, include_virtual: true) do |op, trx_id, block_num|
        puts "#{block_num} :: #{trx_id}; op: #{op.type}"
      end
    end
  end
end
