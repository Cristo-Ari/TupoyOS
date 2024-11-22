return function(TupoyOS)
    TupoyOS.processes = {}
    TupoyOS.addProcess = function(self, filePath)
        table.insert(self.processes, {
            cor = coroutine.create(dofile(filePath)),
            name = "helloProgramm",
            status = "starting",
            iGetEvent = false
        })
    end
    TupoyOS.removeProcess = function(self, key)
        self.coroutines[key] = nil
    end
end