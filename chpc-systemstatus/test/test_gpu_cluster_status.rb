require 'minitest_helper'
require 'mocha/test_unit'
require 'ood_core'
require_relative '../lib/gpu_cluster_status'

class TestGPUClusterStatus < Minitest::Test

	def cluster_mock_owens
		cluster = mock()
		cluster.stubs(:custom_config).returns({:pbs => {:bin => "/opt/torque/bin"}})
		metadata = mock()
		metadata.stubs(:title).returns("Owens")
		cluster.stubs(:id).returns("Owens")
		cluster.stubs(:metadata).returns(metadata)
		cluster
	end

	def cluster_mock_pitzer
		cluster = mock()
		cluster.stubs(:custom_config).returns({:pbs => {:bin => "/opt/torque/bin"}})
		metadata = mock()
		metadata.stubs(:title).returns("Pitzer")
		cluster.stubs(:id).returns("Pitzer")
		cluster.stubs(:metadata).returns(metadata)
		cluster
	end

	def cluster_mock_ruby
		cluster = mock()
		cluster.stubs(:custom_config).returns({:pbs => {:bin => "/opt/torque/bin"}})
		metadata = mock()
		metadata.stubs(:title).returns("Ruby")
		cluster.stubs(:id).returns("Ruby")
		cluster.stubs(:metadata).returns(metadata)
		cluster
	end

	########################################################

	# Owens

	def test_calc_queued_jobs_and_gpus_o
		gpustats = GPUClusterStatus.new(cluster_mock_owens)
		# p "Owens: Queued jobs requesting gpus: " + gpustats.calc_queued_jobs_and_gpus.to_s
		# p "Owens: Number of GPUs requested by queued jobs: " + gpustats.queued_gpus.to_s
		assert gpustats.calc_queued_jobs_and_gpus >= 0
	end

	def test_calc_full_nodes_avail
		gpustats = GPUClusterStatus.new(cluster_mock_owens)
		# p "Owens: Number of full nodes: " + gpustats.calc_full_nodes_avail.to_s
		assert gpustats.calc_full_nodes_avail >= 0
	end

	def test_gpus_unallocated_o
		gpustats = GPUClusterStatus.new(cluster_mock_owens)
		# p "Owens: Number of GPUs unallocated: " + gpustats.calc_gpus_unallocated.to_s
		assert gpustats.calc_gpus_unallocated >= 0
	end

	def test_gpus_available_o
	    gpustats = GPUClusterStatus.new(cluster_mock_owens)
	    assert gpustats.calc_total_gpus > 0
	end

	#######################################################

	# Pitzer

	def test_gpus_unallocated_p
		gpustats = GPUClusterStatus.new(cluster_mock_pitzer)
		 # p "Pitzer: Number of GPUs unallocated: " + gpustats.calc_gpus_unallocated.to_s
		 assert gpustats.calc_gpus_unallocated >= 0
	end

	def test_calc_queued_jobs_and_gpus_p
		gpustats = GPUClusterStatus.new(cluster_mock_pitzer)
		# p "Pitzer: Queued jobs requesting GPUs: " + gpustats.calc_queued_jobs_and_gpus.to_s
		# p "Pitzer: Number of GPUs requested by queued jobs: " + gpustats.queued_gpus.to_s
		assert gpustats.calc_queued_jobs_and_gpus >= 0
	end

	def test_calc_full_nodes_avail_p
		gpustats = GPUClusterStatus.new(cluster_mock_pitzer)
		# p "Pitzer: Number of full nodes: " + gpustats.calc_full_nodes_avail.to_s
		assert gpustats.calc_full_nodes_avail >= 0
	end

	def test_gpus_available_p
	    gpustats = GPUClusterStatus.new(cluster_mock_pitzer)
	    assert gpustats.calc_total_gpus > 0
	end
	#####################################################

	# Ruby

	def test_calc_full_nodes_avail_r
		gpustats = GPUClusterStatus.new(cluster_mock_ruby)
		 # p "Ruby: Number of full nodes: " + gpustats.calc_full_nodes_avail.to_s
		 assert gpustats.calc_full_nodes_avail > 0
	end

	def test_calc_total_gpus_r
		gpustats = GPUClusterStatus.new(cluster_mock_ruby)
		# p "Ruby: Number of total gpus: " + gpustats.calc_total_gpus.to_s
		assert gpustats.calc_total_gpus > 0
	end

	def test_calc_gpus_unallocated_r
		gpustats = GPUClusterStatus.new(cluster_mock_ruby)
		# p "Ruby: Number of gpus unallocated: " + gpustats.calc_gpus_unallocated.to_s
		assert gpustats.calc_gpus_unallocated > 0
	end
end
