from __future__ import print_function
import pickle
import time
import rospy
import numpy as np
import nrp_helpers as nhl
import matlab.engine
from std_msgs.msg import Int32
from hbp_nrp_virtual_coach.virtual_coach import VirtualCoach


# start matlab engine
eng = matlab.engine.start_matlab()
action_topic = rospy.Publisher('action_topic', Int32, queue_size=1)
folder = '~/.opt/nrpStorage/template_husky_0/'


def new_step():
    # build input
    eng.eval('ST = nrp_input(ST, M.task);', nargout=0)

    # get action from matlab
    eng.eval('M = mbrl_control(M, ST);', nargout=0)
    action = int(eng.eval('M.A.a;')) - 1

    # the action goes to the transfer function and is executed
    action_topic.publish(Int32(action))

    # wait until action is done
    while not nhl.raw_data['action_done'].data:
        time.sleep(0.05)
    action_topic.publish(Int32(-1))
    while nhl.raw_data['action_done'].data:
        time.sleep(0.05)

    # the robot is now in a new state
    next_pos, next_dir = nhl.get_state()

    # send new position and new direction from nrp to matlab
    eng.workspace['pos'] = {'x': float(next_pos[0] - 8.0), 
                            'y': float(next_pos[1] - 8.0),
                            'd': float(next_dir)}

    # run action
    eng.eval('ST = nrp_action(ST, M, pos);', nargout=0)

    # execute learning function
    eng.eval('M = mbrl_learning(M, ST);', nargout=0)

    itrial = int(eng.eval('M.itrial;'))

    print('Action:', nhl.get_action_name(action))
    print('Position: %.2f %.2f' % (next_pos[0], next_pos[1]))
    print('Direction: %.2f' % next_dir)
    print('Episode:', itrial)
    print('Step:', int(eng.eval('ST.lpath;')))
    print('-' * 10)

    return itrial, bool(eng.eval('ST.state;'))


def new_episode(vc):
    start_pos = np.asarray([float(eng.eval('ST.start.x;')),
                            float(eng.eval('ST.start.y;'))])
    start_dir = float(eng.eval('ST.start.d;'))

    # reset starting position
    print('Starting position: %.2f %.2f' % (start_pos[0] + 8.0, start_pos[1] + 8.0))
    print('Starting direction: %.2f' % start_dir)

    # get reward location from matlab
    reward_loc = eng.eval('ST.goal;')
    reward_loc = np.asarray([float(reward_loc['x']),
                             float(reward_loc['y'])])
    print('Reward location: %.1f %.1f' % (reward_loc[0], reward_loc[1]))

    with open(folder + 'experiment_configuration.exc', 'r') as file:
        data = file.readlines()
    data[13] = '    <robotPose robotId="husky" x="%.2f" y="%.2f" ' \
               'z="0.5" roll="0.0" pitch="-0.0" yaw="%.2f" />\n' \
               % (start_pos[0] + 8.0, start_pos[1] + 8.0, start_dir)
    with open(folder + 'experiment_configuration.exc', 'w') as file:
        file.writelines(data)

    for _ in range(20):
        while True:
            try:
                sim = vc.launch_experiment('template_husky_0')
                break
            except:
                time.sleep(2)

        # subscribe to topics published by ros
        nhl.perform_subscribers()

        # start experiment
        sim.start()
        time.sleep(2)

        pos, dir_ = nhl.get_state()

        return sim

    return False


def main():
    load = 0

    # start virtual coach
    vc = VirtualCoach(environment='local', storage_username='nrpuser',
                      storage_password='password')

    if load:
        eng.workspace['M'] = pickle.load(open('results/M_%s.pkl' % load, 'rb'))
        eng.workspace['ST'] = pickle.load(open('results/ST_%s.pkl' % load, 'rb'))

    else:
        # initialize matlab structures and get parameters
        eng.eval('[M, ST] = nrp_run();', nargout=0)

    ntrials = int(eng.eval('M.task.ntrials;'))
    itrial = int(eng.eval('M.itrial;'))

    # run training
    trial_done = 1
    while itrial < ntrials:
        eng.eval('ST = nrp_environment(ST, M.task);', nargout=0)

        # start trial
        if trial_done:
            sim = new_episode(vc)
            if not sim:
                break

        itrial, trial_done = new_step()

        if trial_done:
            if bool(eng.eval('ST.r;')):
                print('Reward location found!')
                print('-' * 10)

            # stop experiment
            sim.stop()
            time.sleep(2)

            # save models for postprocessing
            if itrial % 100 == 0:
                pickle.dump(eng.eval('ST;'), open('results/ST_%s.pkl' % str(itrial), 'wb'))
                pickle.dump(eng.eval('M;'), open('results/M_%s.pkl' % str(itrial), 'wb'))


if __name__ == '__main__':
    main()
