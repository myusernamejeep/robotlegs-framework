//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package org.robotlegs.v2.viewmanager
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	import asunit.framework.TestCase;
	import org.robotlegs.v2.viewmanager.listeningstrategies.ListeningStrategies;
	import org.robotlegs.v2.viewmanager.tasks.ITaskHandler;
	import org.robotlegs.v2.viewmanager.tasks.LoggingTask;
	import org.robotlegs.v2.viewmanager.tasks.TaskHandler;
	import org.robotlegs.v2.viewmanager.tasks.TaskHandlerResponse;
	import org.robotlegs.v2.viewmanager.tasks.ViewMediationTask;

	public class DocSpyTest extends TestCase
	{

		/*============================================================================*/
		/* Protected Properties                                                       */
		/*============================================================================*/

		protected var _addedView:Sprite;

		protected var _handler1Count:uint;

		protected var _handler2Count:uint;

		protected var _removedHandlerCount:uint;

		protected var _targetContainer:DisplayObjectContainer;

		protected var _viewToIgnore:Sprite;

		protected var _viewWeCareFor:Sprite;

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var instance:DocSpy;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function DocSpyTest(methodName:String = null)
		{
			super(methodName)
		}


		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function testFailure():void
		{
			assertTrue("Failing test", true);
		}

		public function testInstantiated():void
		{
			assertTrue("instance is DocSpy", instance is DocSpy);
		}

		public function test_addInterestInTwice_doesnt_cause_handler_to_run_twice():void
		{
			_addedView = new Sprite();
			instance.addInterest(_targetContainer, new TaskHandler(ViewMediationTask, handler1, null));
			instance.addInterest(_targetContainer, new TaskHandler(ViewMediationTask, handler1, null));
			_targetContainer.addChild(_addedView);

			assertEquals("AddInterestInTwice doesnt cause handler to run twice", 1, _handler1Count);
		}

		public function test_addInterestIn_results_in_handler_being_run_when_event_fires():void
		{
			_addedView = new Sprite();
			var handler:Function = addAsync(shouldRunHandler, 1000);
			instance.addInterest(_targetContainer, new TaskHandler(ViewMediationTask, handler, null));
			assertTrue("has event listener", _targetContainer.hasEventListener(Event.ADDED_TO_STAGE));
			_targetContainer.addChild(_addedView);
		}

		public function test_add_performance_test():void
		{
			var startTime:uint = getTimer();

			var iLength:uint = 10000;
			for (var i:uint = 0; i < iLength; i++)
			{
				_targetContainer.addChild(new Sprite());
			}

			trace("add perf test: " + (getTimer() - startTime));
		}

		public function test_add_performance_test_with_handler():void
		{
			var taskHandler:ITaskHandler = new TaskHandler(ViewMediationTask, handler1, null);
			instance.addInterest(_targetContainer, taskHandler);

			var startTime:uint = getTimer();

			var iLength:uint = 10000;
			for (var i:uint = 0; i < iLength; i++)
			{
				_targetContainer.addChild(new Sprite());
			}

			trace("add perf test with handler: " + (getTimer() - startTime));
		}

		public function test_adding_2_interests_for_same_event_and_diff_tasks_both_will_fire_even_if_nearest_doesnt_allow():void
		{
			var nearerContainer:Sprite = new Sprite();
			_addedView = new Sprite();
			_targetContainer.addChild(nearerContainer);
			instance.addInterest(_targetContainer, new TaskHandler(LoggingTask, handler2, null));
			instance.addInterest(nearerContainer, new TaskHandler(ViewMediationTask, controlFreakHandler1, null));
			nearerContainer.addChild(_addedView);
			assertEquals("Adding 2 interests for same event causes both to fire if diff tasks - 1 ", 1, _handler1Count);
			assertEquals("Adding 2 interests for same event causes both to fire if diff tasks - 2 ", 1, _handler2Count);
		}

		public function test_adding_2_interests_for_same_event_and_task_causes_both_to_fire_if_nearest_allows():void
		{
			var nearerContainer:Sprite = new Sprite();
			_addedView = new Sprite();
			_targetContainer.addChild(nearerContainer);
			instance.addInterest(_targetContainer, new TaskHandler(ViewMediationTask, handler2, null));
			instance.addInterest(nearerContainer, new TaskHandler(ViewMediationTask, handler1, null));
			nearerContainer.addChild(_addedView);
			assertEquals("Adding 2 interests for same event causes both to fire if nearest permits - 1 ", 1, _handler1Count);
			assertEquals("Adding 2 interests for same event causes both to fire if nearest permits - 2 ", 1, _handler2Count);
		}

		public function test_adding_2_interests_for_same_event_and_task_only_first_will_fire_if_nearest_doesnt_allow():void
		{
			var nearerContainer:Sprite = new Sprite();
			_addedView = new Sprite();
			_targetContainer.addChild(nearerContainer);
			instance.addInterest(_targetContainer, new TaskHandler(ViewMediationTask, handler2, null));
			instance.addInterest(nearerContainer, new TaskHandler(ViewMediationTask, controlFreakHandler1, null));
			nearerContainer.addChild(_addedView);
			assertEquals("Adding 2 interests for same event causes first to fire if nearest doesnt allow - 1 ", 1, _handler1Count);
			assertEquals("Adding 2 interests for same event causes second to not fire if nearest doesnt allow - 2 ", 0, _handler2Count);
		}

		public function test_adding_and_removing_an_interest_results_in_it_not_firing():void
		{
			_addedView = new Sprite();
			var taskHandler:ITaskHandler = new TaskHandler(ViewMediationTask, handler1, null);
			instance.addInterest(_targetContainer, taskHandler);
			instance.removeInterest(_targetContainer, taskHandler);
			_targetContainer.addChild(_addedView);

			assertEquals("Adding and removing an interest results in it not firing", 0, _handler1Count);
		}

		public function test_doesnt_run_removed_for_a_view_that_wasnt_handled():void
		{
			_viewToIgnore = new Sprite();
			var taskHandler:ITaskHandler = new TaskHandler(ViewMediationTask, fussy_handler, remove_handler);
			instance.addInterest(_targetContainer, taskHandler);
			_targetContainer.addChild(_viewToIgnore);
			_targetContainer.removeChild(_viewToIgnore);
			assertEquals("Doesnt run removed for a view that wasnt handled", 0, _removedHandlerCount);
		}

		public function test_get_listeningStrategy_is_AUTO_before_being_set():void
		{
			assertEquals("Get listeningStrategy", ListeningStrategies.AUTO, instance.listeningStrategy);
		}

		public function test_runs_removed_for_a_view_that_was_handled_after_adding():void
		{
			_viewWeCareFor = new Sprite();
			var taskHandler:ITaskHandler = new TaskHandler(ViewMediationTask, fussy_handler, remove_handler);
			instance.addInterest(_targetContainer, taskHandler);
			_targetContainer.addChild(_viewWeCareFor);
			_targetContainer.removeChild(_viewWeCareFor);
			assertEquals("Adding and removing a view we care about results in remove handler firing", 1, _removedHandlerCount);
		}

		public function test_set_listeningStrategy():void
		{
			instance.listeningStrategy = ListeningStrategies.FEWEST_EVENTS;
			assertEquals("Set listeningStrategy", ListeningStrategies.FEWEST_EVENTS, instance.listeningStrategy);
		}

		/*============================================================================*/
		/* Protected Functions                                                        */
		/*============================================================================*/

		protected function controlFreakHandler1(e:Event):uint
		{
			_handler1Count++;
			return TaskHandlerResponse.HANDLED_AND_BLOCKED;
		}


		protected function fussy_handler(e:Event):uint
		{
			if (e.target == _viewWeCareFor)
			{
				return TaskHandlerResponse.HANDLED;
			}
			else
			{
				return TaskHandlerResponse.NOT_HANDLED;
			}
		}

		protected function handler1(e:Event):uint
		{
			_handler1Count++;
			return TaskHandlerResponse.HANDLED;
		}

		protected function handler2(e:Event):uint
		{
			_handler2Count++;
			return TaskHandlerResponse.HANDLED;
		}

		protected function remove_handler(e:Event):uint
		{
			assertEquals("View is correct one", _viewWeCareFor, e.target);
			_removedHandlerCount++;
			return TaskHandlerResponse.HANDLED;
		}

		override protected function setUp():void
		{
			super.setUp();
			instance = new DocSpy();
			_targetContainer = new Sprite();
			_handler1Count = 0;
			_handler2Count = 0;
			_removedHandlerCount = 0;
			addChild(_targetContainer);
		}

		protected function shouldRunHandler(e:Event):uint
		{
			assertEquals("target still contained correctly", _addedView, e.target);
			return TaskHandlerResponse.HANDLED;
		}

		override protected function tearDown():void
		{
			super.tearDown();
			removeChild(_targetContainer);
			_targetContainer = null;
			instance = null;
		}
	}
}
