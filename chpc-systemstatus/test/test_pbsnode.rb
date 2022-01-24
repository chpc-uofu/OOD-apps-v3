require 'minitest_helper'
require 'mocha/test_unit'
require_relative '../lib/pbsnodes_client'

class TestPbsNodes < Minitest::Test

	def cluster_mock_owens
		cluster = mock()
		cluster.stubs(:custom_config).returns({:pbs => {:bin => "/opt/torque/bin"}})
		metadata = mock()
		metadata.stubs(:title).returns("owens")
		cluster.stubs(:id).returns("owens")
		cluster.stubs(:metadata).returns(metadata)
		cluster
	end

	def cluster_mock_pitzer
		cluster = mock()
		cluster.stubs(:custom_config).returns({:pbs => {:bin => "/opt/torque/bin"}})
		metadata = mock()
		metadata.stubs(:title).returns("pitzer")
		cluster.stubs(:id).returns("pitzer")
		cluster.stubs(:metadata).returns(metadata)
		cluster
	end

	# There is no Ruby_mock_cluster as Ruby's GPUs behavior should be the same as that of
	# Owens', as both Clusters have one GPU per node.

	########################################################
	# Tests with the owens cluster

	def test_initialize_o
		PBSNodesClient.new(cluster_mock_owens)
	end

	def test_gpus_available_o
	    pbs = PBSNodesClient.new(cluster_mock_owens)
	    assert "#{pbs.setup.gpus_available}" > "0"
	end

	def test_gpus_used_o
		pbs = PBSNodesClient.new(cluster_mock_owens)
		assert "#{pbs.setup.gpus_used}" >= "0"
	end

	########################################################
	# Tests with the pitzer cluster
	def test_initialize_p
		PBSNodesClient.new(cluster_mock_pitzer)
	end

	def test_gpus_available_p
		pbs = PBSNodesClient.new(cluster_mock_pitzer)
		assert "#{pbs.setup.gpus_available}" > "0"
	end

	def test_gpus_used_p
		pbs = PBSNodesClient.new(cluster_mock_pitzer)
		assert "#{pbs.setup.gpus_used}" >= "0"
	end
end
