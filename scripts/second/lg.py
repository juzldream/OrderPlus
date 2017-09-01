import logging

class Logger():
    def __init__(self, logname, loglevel, logger):
        '''
        '''

        self.logger = logging.getLogger(logger)
        self.logger.setLevel(logging.DEBUG)

        fh = logging.FileHandler(logname)
        fh.setLevel(logging.DEBUG)

        ch = logging.StreamHandler()
        ch.setLevel(logging.DEBUG)
	
	format_dict = {
  		 1 : logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'),
  		 2 : logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'),
  		 3 : logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'),
   	         4 : logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'),
 		 5 : logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
	}

        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        formatter = format_dict[int(loglevel)]
        fh.setFormatter(formatter)
        ch.setFormatter(formatter)

        self.logger.addHandler(fh)
        self.logger.addHandler(ch)

   
    def getlog(self):
        return self.logger



logger = Logger(logname='log.txt', loglevel=1, logger="xxxxxxxxxxxxxxxxxxxxxxxx").getlog()

print logger.error("dddddddddddddddddddddddddd0000")
