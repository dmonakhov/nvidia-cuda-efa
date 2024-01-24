#!/usr/bin/env python3

import argparse
import json
import sys

OUT_OF_PLACE = 0
IN_PLACE = 1

def parse_nccl_output(fin, minBandwidthRequired, minAlgBandwidthRequired):
    errors = []
    lines = raw_output.split('\n')
    output_lines = []
    comments = []
    while True:
        line = fin.readline()
        if not line:
            break
        stripped = line.strip()
        if line != '':
            if line[0] == '#':
                comments.append(stripped)
            else:
                output_lines.append(stripped)

    
    maxAlgBW = [0, 0]
    maxBusBW = [0, 0]
    numWrong = [0, 0]

    '''
    Each line in the output will have 13 tokens; Here's what each token / position is:
size  = 0
count = 1
type  = 2
redop = 3
root = 4
out of place
time = 5
algbw = 6
busbw = 7
Number wrong = 8
in place
time = 9
algbw = 10
busbw = 11
Number wrong = 12
'''
    
    for line in output_lines:
        tokens = line.split() # split on whitespace

        if len(tokens) == 13:
            # Correct number of elements
            maxAlgBW[OUT_OF_PLACE] = max(maxAlgBW[OUT_OF_PLACE], getFloat(tokens[6]))
            maxAlgBW[IN_PLACE] = max(maxAlgBW[IN_PLACE], getFloat(tokens[10]))
            maxBusBW[OUT_OF_PLACE] = max(maxBusBW[OUT_OF_PLACE], getFloat(tokens[7]))
            maxBusBW[IN_PLACE] = max(maxBusBW[IN_PLACE], getFloat(tokens[11]))
            err1 = getInt(tokens[8])
            numWrong[OUT_OF_PLACE] = numWrong[OUT_OF_PLACE] + err1
            err2 = getInt(tokens[12])
            numWrong[IN_PLACE] = numWrong[IN_PLACE] + err2 
            if err1 > 0:
                errors.append("Found %d errors with size %s out of place" % (err1, tokens[0]))
            if err2 > 0: 
                errors.append("Found %d errors with size %s in place" % (err2, tokens[0]))

    if numWrong[OUT_OF_PLACE] > 0:
        errors.append("%d total errors found while performing out of place tests." % numWrong[OUT_OF_PLACE])
    if numWrong[IN_PLACE] > 0:
        errors.append("%d total errors found while performing in place tests." % numWrong[IN_PLACE])

    if maxAlgBW[OUT_OF_PLACE] < minAlgBandwidthRequired:
        errors.append("Maximum achieved out of place alg bandwidth %f is less than required minimum %d" % \
                (maxAlgBW[OUT_OF_PLACE], minAlgBandwidthRequired))
    if maxAlgBW[IN_PLACE] < minAlgBandwidthRequired:
        errors.append("Maximum achieved in place alg bandwidth %f is less than required minimum %d" % \
                (maxAlgBW[IN_PLACE], minAlgBandwidthRequired))

    if maxBusBW[OUT_OF_PLACE] < minBandwidthRequired:
        errors.append("Maximum achieved out of place bus bandwidth %f is less than required minimum %d" % \
                (maxBusBW[OUT_OF_PLACE], minBandwidthRequired))
    if maxBusBW[IN_PLACE] < minBandwidthRequired:
        errors.append("Maximum achieved in place bus bandwidth %f is less than required minimum %d" % \
                (maxBusBW[IN_PLACE], minBandwidthRequired))

    return {}, errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('log_file')
    parser.add_argument("--json", action='store_true',  default=False)
    parser.add_argument('-w', '--max-warnings', type=int, default=10)
    parser.add_argument('-p', '--min-gflops', type=int, default=0)

    args = parser.parse_args()

    with open(args.log_file, 'r') as fin:
        report, errors = parse_nccl_output(fin)
    print(f" errors: {errors}")
    sys.exit(0)
