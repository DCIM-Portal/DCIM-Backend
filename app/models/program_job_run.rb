# A JobRun that has multiple steps
#
# Each step in a ProgramJob has one or more tasks that run in parallel. Once all
# the tasks finish running successfully, the ProgramJob continues to the next
# step.
class ProgramJobRun < JobRun
end
