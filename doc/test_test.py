# coding=utf-8
# 
#

import unittest

class Test(unittest.TestCase):
	def setUp(self):
		self.number = input('Enter a number:')
		self.number = int(self.number)

	def test_case1(self):
		print(self.number)
		self.assertEqual(self.number,10,msg='Your input is not 10')

	def test_case2(self):
		print(self.number)
		self.assertEqual(self.number,20,msg='Your input is not 20')

	@unittest.skip('暂时跳过用例3的测试')
	def test_case3(self):
		print(self.number)
		self.assertEqual(self.number,30,msg='Your input is not 30')

	def tearDown(self):
		print('test over.')

#unittest.main()方法会搜索该模块下所有以test开头的测试用例方法，并自动执行它们。
#执行顺序是命名顺序：先执行test_case1，再执行test_case2
if __name__ == '__main__':
# 	unittest.main()
# 	

# suite = unittest.TestSuite()
# suite.addTest(Test('test_case2'))
# suite.addTest(Test('test_case1'))

# runner = unittest.TextTestRunner()

# runner.run(suite)


	test_dir = './'
	discover = unittest.defaultTestLoader.discover(test_dir,pattern='pps*.py')
	runner = unittest.TextTestRunner()
	runner.run(discover)
