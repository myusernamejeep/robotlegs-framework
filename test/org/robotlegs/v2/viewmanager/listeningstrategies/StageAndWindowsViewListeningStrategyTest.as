//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.v2.viewmanager.listeningstrategies
{
	import asunit.framework.TestCase;

	public class StageAndWindowsViewListeningStrategyTest extends TestCase
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var instance:StageAndWindowsViewListeningStrategy;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function StageAndWindowsViewListeningStrategyTest(methodName:String = null)
		{
			super(methodName)
		}


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function testFailure():void
		{
			assertTrue("Failing test", false);
		}

		public function testInstantiated():void
		{
			assertTrue("instance is StageAndWindowsViewListeningStrategy", instance is StageAndWindowsViewListeningStrategy);
		}

		/*============================================================================*/
		/* Protected Functions                                                        */
		/*============================================================================*/

		override protected function setUp():void
		{
			super.setUp();
			instance = new StageAndWindowsViewListeningStrategy();
		}

		override protected function tearDown():void
		{
			super.tearDown();
			instance = null;
		}
	}
}
