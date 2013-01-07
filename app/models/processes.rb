class Processes < ActiveRecord::Base

  has_many :metrics, :through => :metrics_processes
  belongs_to :thresholdProfile, :foreign_key => "threshold_id"

  attr_accessible :added,:updated, :status, :profile_id, :source_id, :destination_id, :threshold_id

  validates :added, :presence => true
  validates :updated, :presence => true
  validates :status, :presence => true
  validates :profile_id, :presence => true
  validates :source_id, :presence => true
  validates :destination_id, :presence => true
  validates :threshold_id, :presence => true

  protected

  def getStatus
    case self.status
      when 0
           "Inativo"
      when 1
           "Ativo"
      when 2
           "Bloqueado"
      else
         throw :statusException
    end
  end

  catch :statusException do
    puts "Erro: Status não reconhecido"
  end


end
