class ComputingUnit < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  validates :phase, :code, presence: true

  PHASE_OPTIONS = ["init", "init_worker", "ssl_cert", "ssl_session_fetch", "ssl_session_store", "set",
  "rewrite", "balancer", "access", "content", "header_filter", "body_filter", "log"]
end
